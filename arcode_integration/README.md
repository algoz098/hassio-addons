# What you will need:
- Access Token generate in the Internal IOT interface
- For each of the devices have the remoteId
  - To get a remoteId access the Internal IOT interface
  - Create a remote device
  - After saving it will have a ID
- For each of the devices you have to know:
  - the ID of the device: this is the ID in HOMEASSISTANT like 'sensor.button_sensor'
  - pathToValue: where is the value which needs to be reported to ArCode IoT Platform
  - above: OPTIONAL a value which the we want to be above of
  - below: OPTIONAL a value which the we want to be below of
  - forMsTime: a numeric value of milisecs of how much time is allow to be in case of fail

# Example
accessToken: ''
devices:
  - id: sun.sun
    remoteId: 1umId
    pathToValue: attributes.elevation
    above: 1
    forMsTime: 5000
  - id: binary_sensor.updater
    pathToValue: attributes.friendly_name
    remoteId: 1umId
    above: 2
    forMsTime: 3000
