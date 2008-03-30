class Flickr::Auth < Flickr::Base
  def initialize(flickr)
    @flickr = flickr
  end

  # get or return a frob to use for authentication
  def frob
    @frob ||= get_frob
  end

  # generates the authorization url to allow access to a flickr account.
  # 
  # Params
  # * perms (Optional)
  #     sets the permision level to grant on the flickr account.
  #       :read - permission to read private information (DEFAULT)
  #       :write - permission to add, edit and delete photo metadata (includes 'read')
  #       :delete - permission to delete photos (includes 'write' and 'read')
  # 
  def url(perms = :read)
    options = {:api_key => @flickr.api_key, :perms => perms, :frob => self.frob}
    @flickr.sign_request(options)
    Flickr::Base::AUTH_ENDPOINT + "?" + options.collect{|k,v| "#{k}=#{v}"}.join('&')
  end

  # gets the token for the current frob
  def token
    @token ||= get_token rescue nil
  end

  # saves the current token to the cache file if token exists
  # 
  # Param
  # * filename (Optional)
  #     filename of the cache file. defaults to the file passed into Flickr.new
  # 
  def cache_token(filename = @flickr.token_cache)
    if filename and self.token
      cache_file = File.open(filename, 'w+')
      cache_file.print self.token
      cache_file.close
      true
    else
      false
    end
  end

  private
  def get_frob
    rsp = @flickr.send_request('flickr.auth.getFrob')

    rsp.frob.to_s
  end

  def get_token
    if @flickr.token_cache and File.exists?(@flickr.token_cache)
      File.open(@flickr.token_cache, 'r').read
    else
      rsp = @flickr.send_request('flickr.auth.getToken', {:frob => self.frob})

      rsp.auth.token.to_s
    end
  end
end