import Vapor
import Elasticsearch

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    try services.register(ElasticsearchProvider())

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    /// middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    var esConfig = ElasticsearchClientConfig()
    esConfig.hostname = "localhost"
    esConfig.port = 9200
    
    // Configure an Elasticsearch database
    let es = try ElasticsearchDatabase(config: esConfig)

    /// Register the configured SQLite database to the database config.
    var databases = DatabasesConfig()
    databases.add(database: es, as: .elasticsearch)
    services.register(databases)
}
