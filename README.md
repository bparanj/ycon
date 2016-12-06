# README

```
bin/spring binstub --remove --all
```

```
rails g model article name content:text published_on:date
rails db:migrate
```

```ruby
batman = Article.create! name: "Batman", content: <<-ARTICLE
Batman is a fictional character created by the artist Bob Kane and writer Bill Finger. A comic book superhero, Batman first appeared in Detective Comics #27 (May 1939), and since then has appeared primarily in publications by DC Comics. Originally referred to as "The Bat-Man" and still referred to at times as "The Batman", he is additionally known as "The Caped Crusader", "The Dark Knight", and the "World's Greatest Detective," among other titles. (from Railscast)
ARTICLE

superman = Article.create! name: "Superman", content: <<-ARTICLE
Superman is a fictional comic book superhero appearing in publications by DC Comics, widely considered to be an American cultural icon. Created by American writer Jerry Siegel and Canadian-born American artist Joe Shuster in 1932 while both were living in Cleveland, Ohio, and sold to Detective Comics, Inc. (later DC Comics) in 1938, the character first appeared in Action Comics #1 (June 1938) and subsequently appeared in various radio serials, television programs, films, newspaper strips, and video games. (from Wikipedia)
ARTICLE

krypton = Article.create! name: "Krypton", content: <<-ARTICLE
Krypton is a fictional planet in the DC Comics universe, and the native world of the super-heroes Superman and, in some tellings, Supergirl and Krypto the Superdog. Krypton has been portrayed consistently as having been destroyed just after Superman's flight from the planet, with exact details of its destruction varying by time period, writers and franchise. Kryptonians were the dominant people of Krypton. (from Wikipedia)
ARTICLE

lex_luthor = Article.create! name: "Lex Luthor", content: <<-ARTICLE
Lex Luthor is a fictional character, a supervillain who appears in comic books published by DC Comics. He is the archenemy of Superman, and is also a major adversary of Batman and other superheroes in the DC Universe. Created by Jerry Siegel and Joe Shuster, he first appeared in Action Comics #23 (April 1940). Luthor is described as "a power-mad, evil scientist" of high intelligence and incredible technological prowess. (from Wikipedia)
ARTICLE

robin = Article.create! name: "Robin", content: <<-ARTICLE
Robin is the name of several fictional characters appearing in comic books published by DC Comics, originally created by Bob Kane, Bill Finger and Jerry Robinson, as a junior counterpart to DC Comics superhero Batman. The team of Batman and Robin is commonly referred to as the Dynamic Duo or the Caped Crusaders. (from Wikipedia)
ARTICLE
```

```
rails db:seed
```

```
rails g controller articles
```

```ruby
class ArticlesController < ApplicationController
  http_basic_authenticate_with name: "admin", password: "secret",
                               except: [:index, :show]

  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(allowed_params)
    if @article.save
      redirect_to @article, notice: "Created article."
    else
      render :new
    end
  end

  def edit
    @article = Article.find(params[:id])
  end

  def update
    @article = Article.find(params[:id])
    if @article.update_attributes(allowed_params)
      redirect_to @article, notice: "Updated article."
    else
      render :edit
    end
  end
  
  private
  
  def allowed_params
    params.require(:article).permit(:name, :published_on, :content)
  end
end
```

Layout file:

```rhtml
<body>
  <div id="container">
    <% flash.each do |name, msg| %>
      <%= content_tag :div, msg, id: "flash_#{name}" %>
    <% end %>
    <%= yield %>
  </div>
</body>
```

Views are standard.

Routes.

```ruby
resources :articles
root to: 'articles#index'
```

```ruby
development:
  secret_key_base: very-long-string
  http_basic_user: test
  http_basic_password: test
```

We can access the values in secrets.yml in the rails console as follows:

```  
> Rails.application.secrets
 => {:secret_key_base=>"7ae70512d6dcc17f8ea22e057925e9c0d8a4074a75742c6a590ffaba2778034d0be796b42b0ab9bc3b2f5237a3bfa332cd0bbf8fd9760b9ff2885f1f4fb40902", :http_basic_user=>"test", :http_basic_password=>"test", :secret_token=>nil}
> Rails.application.secrets.http_basic_user
 => "test"
> Rails.application.secrets.http_basic_password
 => "test"
```

Add secrets.yml to .gitignore file to prevent checking it in to source control.

Replace the controller hard-coded values:

```ruby
http_basic_authenticate_with name: Rails.application.secrets.http_basic_user, 
							 password: Rails.application.secrets.http_basic_password,
                             except: [:index, :show]
```

Make your code immune to future changes of Rails. Create credentials.rb and define methods that wrap this into methods such as:
lib/credential.rb:

```ruby
class Credential
  def self.http_basic_user
    Rails.application.secrets.http_basic_user
  end
 
  def self.http_basic_password
    Rails.application.secrets.http_basic_password
  end
end
```

In application.rb:

```ruby
config.autoload_paths << Rails.root.join('lib')
```

```ruby
http_basic_authenticate_with name: Credential.http_basic_user, 
							 password: Credential.http_basic_password,
                             except: [:index, :show]
```

Create config/stripe.yml:

```yaml
development:
  api_key: 12345
  api_secret: 6789
test:
  api_key: 12345
  api_secret: 6789
production:
  api_key: <%= ENV["STRIPE_API_KEY"] %>
  api_secret: <%= ENV["STRIPE_API_SECRET"] %>
```

We can now access the values in the rails console like this:
 
``` 
> stripe_config = Rails.application.config_for(:stripe)
 => {"api_key"=>12345, "api_secret"=>6789}
> Rails.application.config.x.stripe.api_key = stripe_config['api_key']
 => 12345
> Rails.application.config.x.stripe.api_secret = stripe_config['api_secret']
 => 6789
> Rails.application.config.x.stripe.api_key
 => 12345
> Rails.application.config.x.stripe.api_secret
 => 6789
```
 
Create config/initializers/stripe.rb.

```ruby
STRIPE_CONFIG = Rails.application.config_for(:stripe)
```

This reads the credential values in the stripe.yml for the current Rails environment. We can add the new methods to retrieve the Stripe credentials in the Credential class.

```ruby
def self.stripe_api_key
  Rails.application.config.x.stripe.api_key = STRIPE_CONFIG['api_key']
end

def self.stripe_api_secret
  Rails.application.config.x.stripe.api_secret = STRIPE_CONFIG['api_secret']
end
```

You can now access the Stripe credentials in your code like this:

```
> Credential.stripe_api_key
 => 12345
> Credential.stripe_api_secret
 => 6789
```


cable.yml


> Rails.application.config.action_cable
 => {:mount_path=>"/cable", :allowed_request_origins=>"http://localhost:3000"}
> Rails.application.config.action_cable.mount_path
 => "/cable"
> Rails.application.config.action_cable.allowed_request_origins
 => "http://localhost:3000"



