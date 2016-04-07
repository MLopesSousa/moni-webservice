require 'json'
require 'redis'

class Cache
	def initialize
		@redis = Redis.new()
	end

	def cache?(key, query, size = 550)
		if(data = @redis.get(key)).nil?
                        @redis.set(key, (data = DataFactory.new().retrieve(query: query, size: size).to_json))
                        @redis.expire(key,14400)
                end

		return data
	end

	# this method must recive an object and return the same kind
	def historical(key, data)
		historical_key = "#{key}:historical"

		if(historical_data = @redis.get(historical_key)).nil? # case there isn't historical data the provided data must be used as historical
			@redis.set(historical_key, set_status(data, true).to_json)
			return set_status(data, true)
		else # case there is a historical data the new data must be confronted 
			return diff(historical_data, data)
		end

	end

	def set_status(data, boo)
     		data.map { |k,v| data[k]["status"] = boo }
            	return data
       	end

	def diff(historical_data, data)
		data = set_status(data, true)
                JSON.parse(historical_data).map do |k,v|
            		if data[k].nil?
             			data[k] = v
                   		data[k]["status"] = false
                	end
              	end

          	return data
	end

	def purge_from_historical_data(key, id)
		historical_key = "#{key}:historical"

		data = JSON.parse(@redis.get(key))
		data.delete(id)
		@redis.set(key, data.to_json)

		historical_data = JSON.parse(@redis.get(historical_key))
		historical_data.delete(id)
		@redis.set(historical_key, historical_data.to_json)
	end

	def purge_from_new_data(key, id)
		data = JSON.parse(@redis.get(key))
		data.delete(id)
		data_F = historical(key, data)
                @redis.set(key, data_F.to_json)
	end

	# this method must return an object
	def cache_data?(key, obj)
                if(data = @redis.get(key)).nil? # this data is a json
			puts "--- none data found, key #{key}"

			data = historical(key, obj.map()).to_json
                        @redis.set(key, data) # redis must cache a json
                        @redis.expire(key,14400)
                end

                return JSON.parse(data) # this data must be changed to object
        end
end
