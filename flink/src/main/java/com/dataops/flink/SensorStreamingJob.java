package com.dataops.flink;

import com.amazonaws.services.kinesisanalytics.runtime.KinesisAnalyticsRuntime;
import com.fasterxml.jackson.databind.ObjectMapper;

import org.apache.flink.api.common.eventtime.WatermarkStrategy;
import org.apache.flink.api.common.functions.MapFunction;
import org.apache.flink.api.common.serialization.SimpleStringSchema;
import org.apache.flink.api.common.typeinfo.Types;
import org.apache.flink.configuration.Configuration;
import org.apache.flink.connector.kinesis.source.KinesisStreamsSource;
import org.apache.flink.connector.kinesis.source.config.KinesisSourceConfigOptions;
import org.apache.flink.streaming.api.datastream.DataStream;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.streaming.api.functions.windowing.ProcessWindowFunction;
import org.apache.flink.streaming.api.windowing.assigners.TumblingEventTimeWindows;
import org.apache.flink.streaming.api.windowing.time.Time;
import org.apache.flink.streaming.api.windowing.windows.TimeWindow;
import org.apache.flink.util.Collector;

import java.time.Duration;
import java.time.Instant;
import java.util.Locale;
import java.util.Map;
import java.util.Properties;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class SensorStreamingJob {

    public static void main(String[] args) throws Exception {

        // 1. Entorno principal de ejecución de Flink
        StreamExecutionEnvironment env =
                StreamExecutionEnvironment.getExecutionEnvironment();

        // 2. Obtener desde AWS/Terraform el ARN del Kinesis Data Stream
        String streamArn = getStreamArn();

        // 3. Configuración del origen Kinesis
        Configuration sourceConfig = new Configuration();

        sourceConfig.set(
                KinesisSourceConfigOptions.STREAM_INITIAL_POSITION,
                KinesisSourceConfigOptions.InitialPosition.LATEST
        );

        KinesisStreamsSource<String> kinesisSource =
                KinesisStreamsSource.<String>builder()
                        .setStreamArn(streamArn)
                        .setSourceConfig(sourceConfig)
                        .setDeserializationSchema(new SimpleStringSchema())
                        .build();

        // 4. Leer eventos JSON desde Kinesis
       DataStream<String> rawEvents =
        env.fromSource(
                kinesisSource,
                WatermarkStrategy.noWatermarks(),
                "Kinesis Sensor Source",
                Types.STRING
        );

        // 5. Convertir JSON -> SensorEvent
        DataStream<SensorEvent> sensorEvents =
                rawEvents
                        .map(new JsonToSensorEvent())
                        .name("Deserialize Sensor JSON");

        // 6. Event Time + Watermarks
        WatermarkStrategy<SensorEvent> watermarkStrategy =
                WatermarkStrategy
                        .<SensorEvent>forBoundedOutOfOrderness(
                                Duration.ofSeconds(10)
                        )
                        .withTimestampAssigner(
                                (event, previousTimestamp) ->
                                        Instant.parse(event.timestamp).toEpochMilli()
                        )
                        .withIdleness(Duration.ofSeconds(30));

        DataStream<SensorEvent> eventsWithWatermarks =
                sensorEvents
                        .assignTimestampsAndWatermarks(watermarkStrategy)
                        .name("Event Time and Watermarks");

        // 7. Agrupar por sensor y crear ventanas de 1 minuto
        DataStream<String> windowResults =
                eventsWithWatermarks
                        .keyBy(event -> event.sensor_id)
                        .window(
                                TumblingEventTimeWindows.of(
                                        Time.minutes(1)
                                )
                        )
                        .process(new SensorWindowFunction())
                        .name("Sensor One Minute Aggregation");

        // 8. El resultado aparecerá en los logs de Flink / CloudWatch
        windowResults.print("WINDOW_RESULT");

        env.execute("Urban Sensors Real-Time Processing");
    }

    private static String getStreamArn() throws Exception {

        Map<String, Properties> applicationProperties =
                KinesisAnalyticsRuntime.getApplicationProperties();

        Properties inputProperties =
                applicationProperties.get("InputStream");

        if (inputProperties == null) {
            throw new IllegalStateException(
                    "No se encontró el grupo de propiedades InputStream."
            );
        }

        String streamArn =
                inputProperties.getProperty("stream.arn");

        if (streamArn == null || streamArn.isBlank()) {
            throw new IllegalStateException(
                    "No se encontró la propiedad stream.arn."
            );
        }

        return streamArn;
    }

    // Representa un evento individual recibido desde Kinesis
    public static class SensorEvent {

        public String sensor_id;
        public double temperature;
        public double humidity;
        public int air_quality_index;
        public String timestamp;

        public SensorEvent() {
        }
    }

    // Convierte cada JSON recibido a un objeto SensorEvent
    public static class JsonToSensorEvent
            implements MapFunction<String, SensorEvent> {

        private static final ObjectMapper mapper =
                new ObjectMapper();

        @Override
        public SensorEvent map(String json) throws Exception {
            return mapper.readValue(json, SensorEvent.class);
        }
    }

    // Procesamiento stateful de cada ventana
    public static class SensorWindowFunction
            extends ProcessWindowFunction<
                    SensorEvent,
                    String,
                    String,
                    TimeWindow> {

                private static final Logger LOG =
                        LoggerFactory.getLogger(SensorWindowFunction.class);

        @Override
        public void process(
                String sensorId,
                Context context,
                Iterable<SensorEvent> events,
                Collector<String> out) {

            int count = 0;

            double temperatureSum = 0;
            double humiditySum = 0;
            double airQualitySum = 0;

            for (SensorEvent event : events) {

                count++;

                temperatureSum += event.temperature;
                humiditySum += event.humidity;
                airQualitySum += event.air_quality_index;
            }

            if (count == 0) {
                return;
            }

            double avgTemperature =
                    temperatureSum / count;

            double avgHumidity =
                    humiditySum / count;

            double avgAirQuality =
                    airQualitySum / count;

            String result = String.format(
                    Locale.US,
                    "sensor=%s | window_start=%s | window_end=%s | events=%d | avg_temperature=%.2f | avg_humidity=%.2f | avg_aqi=%.2f",
                    sensorId,
                    Instant.ofEpochMilli(
                            context.window().getStart()
                    ),
                    Instant.ofEpochMilli(
                            context.window().getEnd()
                    ),
                    count,
                    avgTemperature,
                    avgHumidity,
                    avgAirQuality
            );

            LOG.info("WINDOW_RESULT {}", result);
            out.collect(result);
        }
    }
}