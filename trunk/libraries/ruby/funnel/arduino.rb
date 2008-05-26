#!/usr/bin/env ruby -wKU

require "funnel/iosystem"

module Funnel
  class Arduino
    @@FIRMATA = Configuration.new(Configuration::ARDUINO)
    
    def self.FIRMATA
      return @@FIRMATA
    end

    def initialize(config, host = '127.0.0.1', port = 9000, interval = 33)
      @system = IOSystem.new(config, host, port, interval)

      @analog_pins = config.analog_pins
      @digital_pins = config.digital_pins
    end

    def analog_pin(number)
      return if @analog_pins == nil
      raise ArguentError, "analog pin is not availabe at #{number}" if @analog_pins.at(number) == nil
      @system.io_module(0).port(@analog_pins.at(number))
    end

    def digital_pin(number)
      return if @digital_pins == nil
      raise ArguentError, "digital pin is not availabe at #{number}" if @digital_pins.at(number) == nil
      @system.io_module(0).port(@digital_pins.at(number))
    end
  end
end