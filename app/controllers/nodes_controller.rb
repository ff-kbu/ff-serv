require 'netaddr'
class NodesController < ApplicationController
  before_filter :authenticate_bot, :only => [:update_vpn_status,:vpn_down]
  
  def index
    @registered = Node.registered.includes(statuses: [:vpn_status, :viewpoint],node_registration: :owner)
    @unregistered = Node.unregistered.includes(statuses: [:vpn_status, :viewpoint] ).order('nodes.id asc, node_statuses.created_at desc') 
    ##Note: For getting the latest status it's required to order by status.created_at desc!


    respond_to do |format|
      format.html # index.html.erb
      format.json do
          resp = @registered.map do |node|
           reg = node.node_registration
           {:vpn_status => node.statuses.map {|s| s.vpn_status.name},
             :node => {:id => node.id, :mac => node.mac, :mac_dec => node.mac.to_i(16), 
               :fw_version => ActionView::Base.full_sanitizer.sanitize(node.fw_version),
               :ipv6_link_local => node.link_local_address_short},
             :node_registration => 
                { id: reg.id, 
                  latitude: reg.latitude, 
                  longitude: reg.longitude, 
                  name: ActionView::Base.full_sanitizer.sanitize(reg.name),
                  operator_name: ActionView::Base.full_sanitizer.sanitize(reg.operator_name),
                  operator_email: r_23(ActionView::Base.full_sanitizer.sanitize(reg.operator_email)),
                  loc_str: ActionView::Base.full_sanitizer.sanitize(reg.loc_str),
                  osm_loc: ActionView::Base.full_sanitizer.sanitize(reg.osm_loc),
                  created_at: reg.created_at,
                  updated_at: reg.updated_at
                }
            }
         end
         render json: resp
       end
    end
  end

  #VPN-Status eines Nodes aktualisieren
  def update_vpn_status
    # Request parameters
    mac = params[:mac]
    vpn_status_name = params[:vpn_status]
    vpn_sw = params[:vpn_sw]
    ip = params[:ip]
    viewpoint = params[:viewpoint] || "Unknown"
    vpn_status = VpnStatus.find_by_name vpn_status_name
    node = Node.find_or_create_by_id mac.to_i(16)
    node.update_vpn_status vpn_status,ip,vpn_sw,viewpoint
    render status: :created, :text => ""
  end

  #VPN-Status aller Nodes nach down aendern - VPN wird abgeschaltet (das VPN wird mit dem Namen "vpn" benannt)
  def vpn_down
    vpn_sw = params[:vpn_sw]
    vpn_status = VpnStatus.DOWN
    Node.all.each do |node|
      node.update_vpn_status vpn_status,"0.0.0.0",vpn_sw
    end
    render status: :created, :text => ""
  end

  def stats
    @node = Node.find(params[:node_id])
  end

  def mac
    term = params[:term]
    term.gsub!(/[^A-Fa-f0-9]/,'')
    macs = Node.unregistered.select {|n| n.mac.match(term) }.map {|n| n.to_s}
    if(macs.size > 15)
      macs = macs[0..14] + ["Weitere ..."] 
    end
    render text: macs.to_json
  end
end
