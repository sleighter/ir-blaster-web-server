
class App < Sinatra::Application

  get "/" do
    "Hi World"
  end

  get "/:name" do |name|
    BroadLinkRMMini3.new.method(name.to_sym).call
    return "done"
  end
end
