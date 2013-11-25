require 'faye'
Faye::WebSocket.load_adapter('thin')
bayeux = Faye::RackAdapter.new(:mount => '/faye', :timeout => 25)
run bayeux.listen(9291, { key: "/etc/ssl/certs/www.daljs.org/domain.key", cert: "/etc/ssl/certs/www.daljs.org/ssl.crt" })