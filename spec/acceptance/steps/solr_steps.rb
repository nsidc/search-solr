require File.join('acceptance', 'page_objects', 'solr_search_page')

# module to control solr in acceptance tests
module SolrSteps
  step 'I am using the current environment settings' do
    @environment = {
      host: 'localhost',
      port: '8983',
      collection_path: 'solr',
      collection_name: 'nsidc_oai'
    }
  end

  step 'I search for :terms' do |terms|
    if @page.nil?
      @page = SolrSearchPage.new(@environment[:host], @environment[:port], @environment[:collection_path], @environment[:collection_name])
    end

    @page.query terms
  end

  step 'I should get a valid response with results' do
    expect(@page.valid?).to be_truthy
    expect(@page.total_results).to be > 0
    expect(@page.results.size).to be <= @page.total_results
  end

  step 'The last :n searches should have the same number of results' do |n|
    counts = @page.result_counts
    length = counts.length

    expect(counts.length).to be >= n.to_i

    last_n_counts = counts[(length - n.to_i)..(length - 1)]

    expect(last_n_counts.uniq.size).to eql 1
    expect(last_n_counts.first).to eql counts.last
  end
end

RSpec.configure { |c| c.include SolrSteps }
