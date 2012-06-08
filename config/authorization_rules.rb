authorization do
  role :admin do
    has_permission_on :users, :to => [:all_res]
    has_permission_on :node_registrations, :to => [:all_res, :write_node_id]
    has_permission_on :tincs, :to => [:approve,:manage,:index]
    has_permission_on :nodes, :to => [:register_all,:all_unregistered,:show_ip,:all_res]
  end
  
  # Logged in user
  role :user do
    has_permission_on :nodes, :to => [:index]
    has_permission_on :tincs, :to => [:index]
    
    # Users may edit their registrations
    has_permission_on :node_registrations do
      to :all_res
      if_attribute :user_id => is {user.id}
    end
    has_permission_on :node_registrations do
      to :create
      if_attribute :node_id => is_in { Node.registerable(user.current_ip).map{|n| n.id} }
    end
    has_permission_on :nodes do
      to :show_ip
      if_attribute :current_ip => is {user.current_ip}
    end
    
    
  end
  
  role :guest do
    has_permission_on :nodes, :to => [:index]
  end
  
  # Node, authenticated by mac
  role :node do
    # Nodes are allowed to to create nodes on initial registration
    has_permission_on :nodes, :to => [:create]
    
    # Nodes are allowed to update their data
    has_permission_on :nodes do
      to :update,:read
      if_attribute :wlan_mac => is {user.email}
    end
    
    # Nodes are allowed to submit tinc-requests
    has_permission_on :tincs, :to => [:create]
    
  end
  
  # HTTP-RPC-Call by localhost
  role :localhost do
    has_permission_on :nodes, :to => [:show_ip,:update_status,:update,:index]
  end
end
privileges do
   privilege :all_res do
     includes :create, :read, :update, :delete, :index, :edit
   end
end