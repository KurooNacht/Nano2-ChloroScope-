#include <Arduino.h>
#include <Ticker.h>
#include <WiFi.h>
#include <PubSubClient.h>
#include "DHTesp.h" 

#define WIFI_SSID "los"
#define WIFI_PASSWORD "12345678"
#define MQTT_BROKER "172.20.10.3"  // Replace with your laptop's IP address
#define MQTT_TOPIC_TEMPERATURE "esp32_dor/temperature"
#define MQTT_TOPIC_HUMIDITY "esp32_dor/humidity"

#define DHT_PIN 2 // GPIO 2

WiFiClient wifiClient;
PubSubClient mqtt(wifiClient);
Ticker timerPublish;

char g_szDeviceId[30];
void WifiConnect();
boolean mqttConnect();
void onPublishMessage();
void readSensors();

DHTesp dht;

void setup() {
  Serial.begin(115200);
  delay(100);
  
  Serial.printf("Free Memory: %d\n", ESP.getFreeHeap());
  WifiConnect();
  mqttConnect();
  timerPublish.attach_ms(2000, onPublishMessage);
  dht.setup(DHT_PIN, DHTesp::DHT11);
}

void loop() {
  mqtt.loop();
  readSensors();
}

void readSensors() {
  // Read temperature and humidity
  float temperature = dht.getTemperature();
  float humidity = dht.getHumidity();

  Serial.print("Temperature: ");
  Serial.print(temperature);
  Serial.println(" °C");
  Serial.print("Humidity: ");
  Serial.print(humidity);
  Serial.println(" %");

  // Publish sensor data to MQTT
  mqtt.publish(MQTT_TOPIC_TEMPERATURE, String(temperature).c_str());
  mqtt.publish(MQTT_TOPIC_HUMIDITY, String(humidity).c_str());
}

void onPublishMessage() {
  // Add any data you want to publish periodically here
}

boolean mqttConnect() {
  sprintf(g_szDeviceId, "esp32_%08X",(uint32_t)ESP.getEfuseMac());
  mqtt.setServer(MQTT_BROKER, 1883);
  Serial.printf("Connecting to %s clientId: %s\n", MQTT_BROKER, g_szDeviceId);
  
  boolean status = mqtt.connect(g_szDeviceId);
  if (status == false) {
    Serial.print(" fail, rc=");
    Serial.print(mqtt.state());
    return false;
  }
  Serial.println(" success");
  return mqtt.connected();
}

void WifiConnect() {
  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  while (WiFi.waitForConnectResult() != WL_CONNECTED) {
    Serial.println("Connection Failed! Rebooting...");
    delay(5000);
    ESP.restart();
  }
  Serial.print("System connected with IP address: ");
  Serial.println(WiFi.localIP());
  Serial.printf("RSSI: %d\n", WiFi.RSSI());
}
