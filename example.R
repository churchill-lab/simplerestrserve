library(RestRserve)

RestRserveApp <- RestRserve::RestRserveApplication$new()

AnExample <- function(request, response) {

    name <- request$query[["name"]]

    response$body <- paste0('Hello ', name)

    RestRserve::forward()

}

RestRserveApp$add_get(path = "/", FUN = AnExample)
RestRserveApp$run(http_port = "8001")

