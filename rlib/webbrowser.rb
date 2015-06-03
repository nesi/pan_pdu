require 'net/http'
require 'net/https'
require 'uri'
require 'nokogiri'

#WebBrowser class, derived from Rob Burrowes' Wikarekare source (MIT License).
#Encapsulates simple methods to log into a web site, and pull pages.

class WebBrowser

  attr_reader :host
  attr_accessor :session
  attr_accessor :cookie
  attr_reader :page
  attr_accessor :referer
  attr_accessor :debug
  
  #Create a WebBrowser instance
  # @param host [String] the host we want to connect to
  # @return [WebBrowser]
  def initialize(host)
    @host = host  #Need to do this, as passing nil is different to passing nothing to initialize!
    @cookies = nil
    @debug = false
  end
  
  #Create a WebBrowser instance, connect to the host via http, and yield the WebBrowser instance.
  #  Automatically closes the http session on returning from the block passed to it.
  # @param host [String] the host we want to connect to
  # @param port [Fixnum] (80) the port the remote web server is running on
  # @param block [Proc] 
  # @yieldparam [WebBrowser] the session descriptor for further calls.
  def self.http_session(host, port = 80)
    wb = self.new(host)
    wb.http_session(port) do
      yield wb
    end
  end

  #Create a WebBrowser instance, connect to the host via https, and yield the WebBrowser instance.
  #  Automatically closes the http session on returning from the block passed to it.
  # @param host [String] the host we want to connect to
  # @param port [Fixnum] (443) the port the remote web server is running on
  # @param block [Proc] 
  # @yieldparam [WebBrowser] the session descriptor for further calls.
  def self.https_session(host, port=443)
    wb = self.new(host)
    wb.https_session(port) do
      yield wb
    end
  end

  #Creating a session for http connection
  #  attached block would then call get or post NET::HTTP calls
  # @param port [Fixnum] Optional http server port
  # @param block [Proc] 
  # @yieldparam [Net::HTTP]
  def http_session(port = 80)
    @http = Net::HTTP.new(@host, port)   
    @ssl = @http.use_ssl = false       
    @http.start do |session| #ensure we close the session after the block
      @session = session 
      yield
    end
  end

  #Creating a session for https connection
  #  attached block would then call get or post NET::HTTP calls
  # @param port [Fixnum] Optional http server port
  # @param block [Proc] 
  # @yieldparam [Net::HTTP]
  def https_session(port = 443)
    @http = Net::HTTP.new(@host, port)   
    @ssl = @http.use_ssl = true        #Use https. Doesn't happen automatically!
    @http.verify_mode = OpenSSL::SSL::VERIFY_NONE  #ignore that this is not a signed cert. (as they usually aren't in embedded devices)
    @http.start do |session| #ensure we close the session after the block
      @session = session
      yield
    end
  end
  
  #send the query to the web server using an http get, and returns the response.
  #  Cookies in the response get preserved in @cookie, so they will be sent along with subsequent calls
  #  We are currently ignoring redirects from the PDU's we are querying.
  # @param query [String] The URL after the http://host/ bit and not usually not including parameters, if form_values are passed in
  # @param form_values [Hash{String=>Object-with-to_s}] The parameter passed to the web server eg. ?key1=value1&key2=value2...
  # @return [String] The Net::HTTPResponse.body text response from the web server
  def get_page(query,form_values=nil)
    query += form_values_to_s(form_values, query.index('?') != nil) #Should be using req.set_form_data, but it seems to by stripping the leading / and then the query fails.
    #$stderr.puts query
    url = @ssl ? URI.parse("https://#{@host}/#{query}") : URI.parse("http://#{@host}/#{query}")
    $stderr.puts url if @debug
    req = Net::HTTP::Get.new(url.path)    
    header = {'User-Agent' => 'Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.1.5) Gecko/20091102 Firefox/3.5.5', 'Content-Type' => 'application/x-www-form-urlencoded'}    
    header['Cookie'] = @cookie if @cookie != nil
    $stderr.puts header['Cookie']  if debug
    req.initialize_http_header( header )

    response = @session.request(req)
    if(response.code.to_i != 200)

      if(response.code.to_i == 302)
          #ignore the redirects.
          #$stderr.puts "302"
          #response.each {|key, val| $stderr.printf "%s = %s\n", key, val }  #Location seems to have cgi params removed. End up with .../cginame?&
          #$stderr.puts "Redirect to #{response['location']}"   #Location seems to have cgi params removed. End up with .../cginame?&
          if (response_text = response.response['set-cookie']) != nil
            @cookie =  response_text
          else
            @cookie = ''
          end
          #$stderr.puts
        return
      end
      raise "#{response.code} #{response.message}"
    end

    if (response_text = response.response['set-cookie']) != nil
      @cookie =  response_text
    else
      @cookie = ''
    end

    return response.body
  end

  #send the query to the web server using an http post, and returns the response.
  #  Cookies in the response get preserved in @cookie, so they will be sent along with subsequent calls
  #  We are currently ignoring redirects from the PDU's we are querying.
  # @param query [String] The URL after the http://host/ bit and not usually not including parameters, if form_values are passed in
  # @param form_values [Hash{String=>Object-with-to_s}] The parameter passed to the web server eg. ?key1=value1&key2=value2...
  # @return [String] The Net::HTTPResponse.body text response from the web server
  def post_page(query,form_values=nil)
    #query += form_values_to_s(form_values) #Should be using req.set_form_data, but it seems to by stripping the leading / and then the query fails.
   #$stderr.puts query
    url = @ssl ? URI.parse("https://#{@host}/#{query}") : URI.parse("http://#{@host}/#{query}")
    $stderr.puts url if @debug
    req = Net::HTTP::Post.new(url.path)
    header = {'User-Agent' => 'Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.1.5) Gecko/20091102 Firefox/3.5.5', 'Content-Type' => 'application/x-www-form-urlencoded'}    
    header['Cookie'] = @cookie if @cookie != nil
    $stderr.puts header['Cookie']  if debug
    req.initialize_http_header( header )
    req.set_form_data(form_values, '&') if form_values != nil

      response = @session.request(req)
      if(response.code.to_i != 200)
        if(response.code.to_i == 302)
            #ignore the redirects. 
            #$stderr.puts "302"
            #response.each {|key, val| $stderr.printf "%s = %s\n", key, val }  #Location seems to have cgi params removed. End up with .../cginame?&
            #$stderr.puts "Redirect of Post to #{response['location']}" #Location seems to have cgi params removed. End up with .../cginame?&
            if (response_text = response.response['set-cookie']) != nil
              @cookie =  response_text
            else
              @cookie = ''
            end
            #$stderr.puts
          return
        end
        raise "#{response.code} #{response.message}"
      end

      if (response_text = response.response['set-cookie']) != nil
        @cookie =  response_text
      else
        @cookie = ''
      end

      @response = response
      
      return response.body
  end
=begin  
  #Take an html response with an embedded table and turn the table rows into Array rows.
  #  @example [ [row1_column1, row1_column2],...]
  #  @param s [String] The html response body
  #  @return [Array] An Array of table rows extracted from the Table
  #
  def extract_table(s)
    #Document.new(s).elements["HTML/BODY/TABLE/TR"].each do |tr|
    entry = true
    doc = Hpricot(s)
    (doc/"table/tr").each do |tr|
      new_row = []
      (tr/"td").each do |cell|
        new_row << cell.inner_text.strip #Want the cell contents less the format tags, stripping leading and trailing spaces.
      end
      if(entry == true)
        entry = false
        row_names << new_row
        row_names.each_with_index { |v,i| index[v] = i } #Create a hash index of row names to their index
      else
        resultset << new_row
      end
    end
  end
=end

  #Extract form field values from the html body.
  # @param body [String] The html response body
  # @return [Hash] Keys are the field names, values are the field values
  def extract_input_fields(body)
    entry = true
    @inputs = {}
    doc = Nokogiri::HTML(body)
    doc.xpath("//form/input").each do |f|
      @inputs[f.get_attribute('name')] = f.get_attribute('value')
    end
  end

  #Extract links from the html body.
  # @param body [String] The html response body
  # @return [Hash] Keys are the link text, values are the html links
  def extract_link_fields(body)
    entry = true
    @inputs = {}
    doc = Nokogiri::HTML(body)
    doc.xpath("//a").each do |f|
      return URI.parse( f.get_attribute('href') ).path if(f.get_attribute('name') == 'URL$1')
    end
    return nil
  end

  #Take a hash of the params to the post and generate a safe URL string.
  # @param form_values [Hash] Keys are the field names, values are the field values
  # @param has_q [Boolean] We have a leading ? for the html get, so don't need to add one.
  # @return [String] The 'safe' text for fields the get or post query to the web server
  def form_values_to_s(form_values=nil, has_q = false)
    return "" if form_values == nil
    s = (has_q == true ? "" : "?")
    first = true
    form_values.each do |key,value|
      s += "&" if !first
      s += "#{URI.escape(key)}=#{URI.escape(value)}"
      first = false
    end
    return s
  end
end
