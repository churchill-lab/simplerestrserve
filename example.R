#!/usr/bin/env Rscript

## ---- load packages ----

library(RestRserve)

## ---- add some middleware ----

library(memCompression)

middleware_gzip <- Middleware$new(
    process_request = function(request, response) {
        msg = list(
            middleware = "middleware_gzip",
            request_id = request$id,
            timestamp = Sys.time()
        )
        msg = to_json(msg)
        cat(msg, sep = '\n')
    },
    process_response = function(request, response) {
        enc = request$get_header("accept-encoding")

        if (!is.null(enc) && any(grepl("gzip", enc))) {
            response$set_header("Content-encoding", "gzip")
            raw<-charToRaw(response$body)
            response$set_body(memCompression::compress(raw, "gzip"))
            response$encode = identity
        }
    
        msg = list(
            middleware = "middleware_gzip",
            request_id = request$id,
            timestamp = Sys.time()
        )
        
        msg = to_json(msg)
        cat(msg, sep = '\n')
    },
    id = "gzip"
)


## ---- create handler for the HTTP requests ----

# simple response
hello_handler = function(request, response) {
  response$body = "Hello, World!"
}

# handle query parameter
hello_query_handler = function(request, response) {
    # user name
    name <- request$parameters_query[["name"]]
  
    # default value
    if (is.null(name)) {
        name = "anonymous"
    }

    response$body <- sprintf("Hello, %s!", name)
}

# handle path variable
hello_path_handler = function(request, response) {
    # user name
    name <- request$parameters_path[["name"]]
    response$body <- sprintf("Hello, %s!", name)
}


installed_packages_handler = function(request, response) {
    response$content_type <- "application/json"

    ip <- as.data.frame(installed.packages()[,c(1,3:4)])
    rownames(ip) <- NULL
    ip <- ip[is.na(ip$Priority),1:2,drop=FALSE]
    response$body <- jsonlite::toJSON(ip)    
}


## ---- create application -----

application = Application$new(
    content_type = "text/plain"
)

application$append_middleware(middleware_gzip)

## ---- register endpoints and corresponding R handlers ----

application$add_get(
    path = "/hello",
    FUN = hello_handler
)

application$add_get(
    path = "/hello/query",
    FUN = hello_query_handler
)

application$add_get(
    path = "/hello/path/{name}",
    FUN = hello_path_handler,
    match = "regex"
)

application$add_get(
    path = "/packages",
    FUN = installed_packages_handler
)

## ---- start application ----
backend = BackendRserve$new(
    content_type = 'application/json'
)
backend$start(
    application, 
    http_port = 8001, 
    encoding  = "utf8", 
    port      = 6311, 
    daemon    = "disable", 
    pid.file  = "Rserve.pid")
