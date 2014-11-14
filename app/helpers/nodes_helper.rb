module NodesHelper

  def ping_image_url(node)
    #Old: http://stat.kbu.freifunk.net/nodes/159387616943362/stats/ping.png?secs=3600&width=400&height=160&no_summary=1
    #New: //kbu.freifunk.net/cserv/nodes/18687086762806/stats/ping.png?secs=86400&width=600&height=200&target=ping-fdd3:5d16:b5dd:3::6.rrd
    url = "https://kbu.freifunk.net/cserv/nodes/#{node.mac.to_i(16)}/stats/ping.png?secs=3600&width=400&height=160&no_summary=2&target=ping-fdd3:5d16:b5dd:3::6.rrd"
  end

  def thruput_image_url(node,interface)
    url = "https://kbu.freifunk.net/cserv/nodes/#{node.mac.to_i(16)}/stats/interface/octets-#{interface}.png?secs=3600&width=400&height=160&no_summary=2"
  end
end
