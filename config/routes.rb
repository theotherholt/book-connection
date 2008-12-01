ActionController::Routing::Routes.draw do |map|
  map.resource  :account,
                :only => [ 'new', 'create', 'edit', 'update', 'show' ]
  map.resource  :session,
                :only => [ 'new', 'create', 'destroy' ]
  map.resources :posts,
                :only => [ 'index', 'new', 'create', 'edit', 'update', 'destroy' ],
                :new => {
                  'review' => :post
                },
                :member => {
                  'purchase' => :any,
                  'destroy'  => :delete,
                  'confirm'  => :any,
                  'relist'   => :post
                }
  map.resources :books,
                :only => [ 'index', 'show' ],
                :collection => {
                  'search'        => :any,
                  'validate_isbn' => :any
                }
  
  ##
  # Setup main routes.
  map.with_options(:controller => 'main') do |main|
    main.contact  '/main/contact', :action => 'contact'
    main.about    '/main/about',   :action => 'about'
    main.privacy  '/main/privacy', :action => 'privacy'
  end
  
  ##
  # Get that activation link working.
  map.activate '/activate/:id/:activation',
    :controller => 'accounts',
    :action     => 'activate',
    :id         => /\d+/,
    :activation => nil
  
  ###
  ## Setup the root of the site to point to the MainController.
  map.root :controller => 'main'
end
