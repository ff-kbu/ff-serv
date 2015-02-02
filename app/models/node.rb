class Node < ActiveRecord::Base
  require 'netaddr'
  require 'net/http'
  using_access_control
  validates_format_of :mac, :with => /^[0-9a-f]{12}$/i
  
  attr_accessible :id
  has_many :fastds
  has_many :node_statuses
  has_many :tincs
  has_one  :valid_tinc, :conditions => 'approved_at IS NOT NULL and revoked_at IS NULL', :class_name => 'Tinc'
  has_one :node_registration
  has_many :statuses, :class_name => 'NodeStatus', :include => ['vpn_status']
  
  scope :registered, joins(:node_registration).includes([:node_statuses]) 
  scope :unregistered,where("nodes.id not in (select n2a.id from nodes n2a where n2a.id in (SELECT nr.node_id from node_registrations nr))")
  scope :reg_able, unregistered.with_permissions_to(:register)

  scope :online, joins(:statuses).where(:node_statuses => {:vpn_status_id => VpnStatus.UP.id})

  # It's offline,
  def last_status
    @last_status ||= self.statuses.order('created_at DESC').first
  end

  def online?
    self.status_by_viewpoint.values.includes(VpnStatus.UP)
  end

  # Return node status for each known viewpoint
  def status_by_viewpoint
    @status_by_viewpoint ||= Hash[self.statuses.map {|s| [s.viewpoint,s]}]
  end


  def self.unregistered_home(ip_address) 
    Node.unregistered.joins([:statuses]).where(:node_statuses => 
      {:ip => ip_address}
    )
  end
  
  def to_s
    self.mac.scan(/../).join(':')
  end

  def update_vpn_status(vpn_status,ip,vpn_sw,viewpoint)
    ip_str = "#{ip}"
    vpn_sw_str = "#{vpn_sw}"
    vp = Viewpoint.find_or_create_by_name viewpoint
    
    Node.transaction do
      logger.error "VP id is #{vp.id}"
      old_status = self.statuses.find_by_viewpoint_id(vp.id) || NodeStatus.new
      old_status.update_attributes(
       :fw_version => old_status.fw_version,
       :initial_conf_version => old_status.initial_conf_version,
       :node_id => self.id,
       :vpn_status_id => vpn_status.id,
       :vpn_sw_name => vpn_sw_str,
       :ip => ip_str,
       :viewpoint_id => vp.id)
    end
  end
  
  # No leading 0 in groups
  def link_local_address_short
    bs = self.mac.scan(/../).join(':')
    addr = NetAddr::EUI.create(bs)
    addr.link_local(:Short => true)
  end
  
  def mac
    self.id.to_s(16).rjust(12,'0') #ID => mac. Für backwards comp.: format id has string (hexadecimal) having 12 letters
  end


  def link_local_address
    bs = self.mac.scan(/../).map {|c| c.to_i(16)}
    #Flip universal bit (6-th) bit of first octet - count from beginning
    bs[0] ^= 2
    b = bs.map {|bm| "%02x" % bm}
    return unless b.size == 6 #Hack for broken numbers
    first = b[0] + b[1]
    second = b[2] + "ff"
    third = "fe" + b[3]
    fourth = b[4] + b[5]
    "fe80::" + [first,second,third,fourth].join(':')
  end
end
