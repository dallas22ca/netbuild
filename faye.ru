
# Faye::WebSocket.load_adapter('thin')
# bayeux = Faye::RackAdapter.new(:mount => '/faye', :timeout => 25)
# run bayeux


require 'faye'
require 'eventmachine'
require 'rack'
require 'thin'

Faye::WebSocket.load_adapter('thin')

EM.run {
  thin = Rack::Handler.get('thin')

  thin.run(App, :Port => 9291) do |server|
    server.ssl_options = {
      :private_key_file => "/etc/ssl/certs/www.daljs.org/domain.key",
      :cert_chain_file  => "/etc/ssl/certs/www.daljs.org/ssl.crt"
    }
    server.ssl = true
  end
}