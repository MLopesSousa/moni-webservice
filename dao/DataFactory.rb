require 'rubygems'
require 'rest-client'
require 'date'
require 'jbuilder'
require 'json'

class DataFactory
	def retrieve(param = {})
		puts "going to elasticsearch, query #{param[:query]}"
		_q = param[:query]

		# build json
		query = Jbuilder.encode do |json|
                        json.query do
                                json.filtered do
                                        json.query do
                                                json.bool do
                                                        json.should do
                                                                json.query_string do
									json.query _q
                                                                end
                                                        end
                                                end
                                        end
                                end
                        end
                        json.size param[:size]
                        json.sort do
                                json.set! :@timestamp do
                                        json.order 'desc'
                                        json.ignore_unmapped true
                                end
                        end
                end

		# build URL
		index = "logstash-#{Date.today.strftime("%Y.%m.%d").to_s}"
	        url="http://172.30.121.246:9200/" + index + "/_search"
		data = JSON.parse(RestClient.post(url, query, :content_type => :json ))
		ret ||= data['hits']['hits'] || []
	end
end
#puts DataFactory.new().retrieve(query: '@fields.tipo:"APPLICATION"', size: 400)
