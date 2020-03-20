require_dependency 'expense'

module SerialNumberField
  module ExpensePatch
    extend ActiveSupport::Concern

    included do
      after_save :assign_serial_number!
    end

    def assign_serial_number!
      serial_number_fields.each do |cf|
        next if assigned_serial_number?(cf)

        target_custom_value = serial_number_custom_value(cf)
        new_serial_number = cf.format.generate_value(cf, self)

        if target_custom_value.present?
          target_custom_value.update_attributes!(
            :value => new_serial_number)
        end
      end
    end

    def assigned_serial_number?(cf)
      serial_number_custom_value(cf).try(:value).present?
    end

    def serial_number_custom_value(cf)
      CustomValue.where(:custom_field_id => cf.id,
        :customized_type => 'Expense',
        :customized_id => self.id).first
    end

    def serial_number_fields
      available_custom_fields.select do |value|
        value.field_format == SerialNumberField::Format::NAME
      end
    end

  end
end

SerialNumberField::ExpensePatch.tap do |mod|
  Expense.send :include, mod unless Expense.include?(mod)
end
