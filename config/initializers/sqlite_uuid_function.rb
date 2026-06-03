require "securerandom"

ActiveSupport.on_load(:active_record_sqlite3adapter) do
  module CityOfBrassSqliteUuidFunction
    private

    def configure_connection
      super
      raw_connection.create_function("uuid", 0) { |function| function.result = SecureRandom.uuid }
    end
  end

  prepend CityOfBrassSqliteUuidFunction
end
