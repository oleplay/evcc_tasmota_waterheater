# Heating element control through evcc

Control a water heating element with excess solar power.

A ESP32 controls a three phase voltage regulator in 18 steps through a 0-5V in control signal.

It also emulates an go-e V3 Wallbox which enables the control via evcc.

A further api layer implemented in FastAPI is required due to some quirks in the implementation of Berry in Tasmota. 

To implement the 18 control steps the esp is able to simulate phase switching through evcc 

## Hardware
- 1x ESP32 Node MCU
- 2x 12V Din Rail Relais
- 1x 12V PSU (Meanwell HDR-15-12)
- 1x 4NO Contactor
- 1x LSA-TH3P70Y 15kW three phase voltage regulator
- 1x Heating Element (9kW)
- 1x KSD9700-xx-NC (70°C) thermal cutoff switch
- 1x DS18B20
  
Board Hardware
- 1x BS170
- 2x S8050
- 1x LM358P
- Various connectors
- Various resistors

## Software requirements
- Evcc instance with sponsor token
- Docker host for api
  
## Software Architecture

Evcc -- API -- Tasmota(Berry)

## Parameters that need adjusting
The lookup dict in the Berry Script should be adjusted to your own values.

{Current : DAC Voltage}

lookup_single values correspond to 230VxCurrent

lookup_triple values correspond to 3x230VxCurrent

## TODO
-  Add current sensing using current transformers
-  Improve Documentation
-  Add Pictures
