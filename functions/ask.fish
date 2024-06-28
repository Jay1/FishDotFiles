function ask --description "Ask Perplexity AI"
    set query (string join ' ' $argv)
    if test -z "$query"
        echo "Please provide a query to ask Perplexity."
        return 1
    end

    # Replace this with the actual API endpoint and authentication details
    set api_endpoint "https://api.perplexity.ai/v1/ask"
    set api_key your_api_key_here

    set response (curl -s -X POST -H "Content-Type: application/json" \
                       -H "Authorization: Bearer $api_key" \
                       -d "{\"query\": \"$query\"}" \
                       $api_endpoint)

    echo $response
end
