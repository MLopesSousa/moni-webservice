require 'rubygems'
require 'json'
require 'redis'

require 'sinatra'
require 'sinatra/cross_origin'

require File.join(File.expand_path(File.dirname(__FILE__)), '../dao/ApplicationDAO')
require File.join(File.expand_path(File.dirname(__FILE__)), '../dao/TargetDAO')
require File.join(File.expand_path(File.dirname(__FILE__)), '../dao/ServerDAO')
require File.join(File.expand_path(File.dirname(__FILE__)), '../dao/HostDAO')

before do
    content_type 'application/json'
    $redis = Redis.new
end

configure do
        enable :cross_origin
        set :allow_origin, :any
        set :allow_methods, [:get, :post, :put, :delete]
end

set :port, 8090
set :bind, '0.0.0.0'

get '/Observer/v2/applications' do
	ApplicationDAO.new().list().to_json
end


get '/Observer/v2/applications/:key' do
	ApplicationDAO.new().select(params['key']).to_json
end

get '/Observer/v2/applications/purge/:key' do
        ApplicationDAO.new().purge(params['key']).to_json
end

get '/Observer/v2/targets' do
	TargetDAO.new().list().to_json
end


get '/Observer/v2/targets/:key' do
	TargetDAO.new().select(params['key']).to_json
end

get '/Observer/v2/targets/purge/:key' do
        TargetDAO.new().purge(params['key']).to_json
end

get '/Observer/v2/servers' do
	ServerDAO.new().list().to_json
end


get '/Observer/v2/servers/:key' do
	ServerDAO.new().select(params['key']).to_json
end

get '/Observer/v2/servers/purge/:key' do
        ServerDAO.new().purge(params['key']).to_json
end

get '/Observer/v2/servers/status/:key' do
	host = params['key'].split(':')[0]
	port = params['key'].split(':')[1]
        
	ServerDAO.new().status(host, port).to_json
end

get '/Observer/v2/hosts' do
        HostDAO.new().list().to_json
end

get '/Observer/v2/hosts/:key' do
        HostDAO.new().select(params['key']).to_json
end

get '/Observer/v2/hosts/purge/:key' do
        HostDAO.new().purge(params['key']).to_json
end


get '/Observer/v2/stats' do
	ret = []
        ret << { :applications => ApplicationDAO.new().list(), 
		 :targets => TargetDAO.new().list(),
		 :servers => ServerDAO.new().list(),
		 :hosts => HostDAO.new().list()
	       }
	return ret.to_json
end
