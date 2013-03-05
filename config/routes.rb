AsapanaStore::Application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
  
  namespace :cms_admin, :path => ComfortableMexicanSofa.config.admin_route_prefix, :except => :show do
    get '/', :to => 'base#jump'
    resources :sites do
      resources :pages do
        get  :form_blocks,    :on => :member
        get  :toggle_branch,  :on => :member
        put :reorder,         :on => :collection
        resources :revisions, :only => [:index, :show, :revert] do
          put :revert, :on => :member
        end
      end
      resources :files do
        put :reorder, :on => :collection
      end
      resources :layouts do
        put :reorder, :on => :collection
        resources :revisions, :only => [:index, :show, :revert] do
          put :revert, :on => :member
        end
      end
      resources :snippets do
        put :reorder, :on => :collection
        resources :revisions, :only => [:index, :show, :revert] do
          put :revert, :on => :member
        end
      end
      resources :categories
      get 'dialog/:type' => 'dialogs#show', :as => 'dialog'
    end
  end
  
  scope :controller => :cms_content do
    get 'cms-css/:site_id/:identifier' => :render_css,  :as => 'cms_css'
    get 'cms-js/:site_id/:identifier'  => :render_js,   :as => 'cms_js'
    
    if ComfortableMexicanSofa.config.enable_sitemap
      get '(:cms_path)/sitemap' => :render_sitemap,
        :as           => 'cms_sitemap',
        :constraints  => {:format => /xml/},
        :format       => :xml
    end
    
    get '/site/:path' => :render_html,  :as => 'cms_html'
  end
  
end
