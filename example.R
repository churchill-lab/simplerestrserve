#!/usr/bin/env Rscript

## ---- load packages ----

library(RestRserve)


## ---- create handler for the HTTP requests ----

# simple response
hello_handler = function(request, response) {
  response$body = "Hello, World!"
}

# handle query parameter
heelo_query_handler = function(request, response) {
    # user name
    name = request$parameters_query[["name"]]
  
    # default value
    if (is.null(name)) {
        name = "anonymous"
    }
  
    response$body = sprintf("Hello, %s!", name)
}

# handle path variable
hello_path_handler = function(request, response) {
    # user name
    name = request$parameters_path[["name"]]
    response$body = sprintf("Hello, %s!", name)
}


## ---- create application -----

application = Application$new(
    content_type = "text/plain"
)


## ---- register endpoints and corresponding R handlers ----

application$add_get(
    path = "/hello",
    FUN = hello_handler
)

application$add_get(
    path = "/hello/query",
    FUN = heelo_query_handler
)

application$add_get(
    path = "/hello/path/{name}",
    FUN = hello_path_handler,
    match = "regex"
)


## ---- start application ----
backend = BackendRserve$new()
backend$start(application, http_port = 8001)
