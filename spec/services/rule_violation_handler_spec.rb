require 'rails_helper'

RSpec.describe RuleViolationHandler do
  let!(:device)        { create(:device) }
  let!(:sensor)        { create(:sensor, device: device) }
  let!(:sensor_data_0) { create(:sensor_data, sensor: sensor, value: 10) }
  let!(:sensor_data_1) { create(:sensor_data, sensor: sensor, value: 11) }
  let!(:sensor_data_2) { create(:sensor_data, sensor: sensor, value: 12) }

  let!(:alarm_rule_1)  { create(:alarm_rule, sensor: sensor, rule_type: 'max_value', value: 20) }
  let!(:alarm_rule_2)  { create(:alarm_rule, sensor: sensor, rule_type: 'max_value', value: 30) }

  describe '#maybe_create_or_update_violation' do
    it "doesn't create violation if all sensor_data are alright" do
      expect {
        RuleViolationHandler.new(device, [sensor_data_0, sensor_data_1, sensor_data_2]).maybe_create_or_update_violation
      }.to_not change { RuleViolation.count }
    end

    it 'creates a violation if sensor_data is outside the allowed range' do
      sensor_data_3 = create(:sensor_data, sensor: sensor, value: 21)
      expect {
        RuleViolationHandler.new(device, [sensor_data_0, sensor_data_1, sensor_data_2, sensor_data_3]).maybe_create_or_update_violation
      }.to change { RuleViolation.count }.by(1)
    end

    it 'creates multiple violations if sensor_data is outside the allowed range' do
      sensor_data_3 = create(:sensor_data, sensor: sensor, value: 21)
      sensor_data_4 = create(:sensor_data, sensor: sensor, value: 31)
      expect {
        RuleViolationHandler.new(device, [sensor_data_0, sensor_data_1, sensor_data_2, sensor_data_3, sensor_data_4]).maybe_create_or_update_violation
      }.to change { RuleViolation.count }.by(2)
    end

    it 'updates an existing violation if there is already one' do
      RuleViolationHandler.new(device, [create(:sensor_data, sensor: sensor, value: 21)]).maybe_create_or_update_violation
      expect {
        RuleViolationHandler.new(device, [create(:sensor_data, sensor: sensor, value: 25)]).maybe_create_or_update_violation
      }.to change { RuleViolation.first.violation_text }
    end
  end

  describe '#maybe_close_violation' do
    it "doesn't do anything if there isn't any violation" do
      expect {
        RuleViolationHandler.new(device, [sensor_data_0, sensor_data_1, sensor_data_2]).maybe_close_violation
      }.to_not change { RuleViolation.open.count }
    end

    it 'closes a violation if sensor_data is inside the allowed range' do
      RuleViolationHandler.new(device, [create(:sensor_data, sensor: sensor, value: 21)]).maybe_create_or_update_violation
      expect {
        RuleViolationHandler.new(device, [sensor_data_0, sensor_data_1, sensor_data_2]).maybe_close_violation
      }.to change { RuleViolation.open.count }.by(-1)
    end
  end
end
