use actix_web::{get, web, App, HttpRequest, HttpResponse, HttpServer, Responder};
use lazy_static::lazy_static;
use serde::Serialize;
use std::env;
use std::sync::Mutex;
use std::time::{Duration, SystemTime};
use sysinfo::System;
use uuid::Uuid;

const DEFAULT_PORT: &str = "8080";

lazy_static! {
    static ref START_TIME: Mutex<SystemTime> = Mutex::new(SystemTime::now());
}

#[derive(Serialize)]
struct HealthStatus {
    memory_usage: String,
    cpu_usage: String,
}

#[get("/")]
async fn root() -> impl Responder {
    let hostname: String = env::var("HOSTNAME").unwrap_or_else(|_| "localhost".to_string());
    let port = env::var("PORT").unwrap_or_else(|_| DEFAULT_PORT.to_string());

    format!("Hello, world from {} port {}!", hostname, port)
}

#[get("/new_uuid")]
async fn new_uuid() -> impl Responder {
    HttpResponse::Ok().body(Uuid::new_v4().to_string())
}

#[get("/myip")]
async fn my_ip(req: HttpRequest) -> impl Responder {
    let client_ip = get_client_ip(&req);
    HttpResponse::Ok().body(client_ip)
}

#[get("/uptime")]
async fn uptime() -> impl Responder {
    let uptime = get_uptime();
    HttpResponse::Ok().body(format!("Uptime: {}", uptime))
}

#[get("/soh")]
async fn soh() -> impl Responder {
    HttpResponse::Ok().body("Running")
}

#[get("/health")]
async fn health() -> impl Responder {
    let mut system: System = System::new();
    system.refresh_all();

    let memory_usage: String = format!("{:.2} MB", system.used_memory() as f32 / 1024.0 / 1024.0);
    let cpu_usage: String = format!("{:.2}%", system.global_cpu_info().cpu_usage());

    let health_status: HealthStatus = HealthStatus {
        memory_usage,
        cpu_usage,
    };

    HttpResponse::Ok().json(health_status)
}

async fn not_found() -> impl Responder {
    HttpResponse::NotFound().body("404 Not Found")
}

fn get_client_ip(req: &HttpRequest) -> String {
    actix_web::dev::ConnectionInfo::peer_addr(&req.connection_info())
        .map_or_else(|| "Unknown".to_string(), |addr| addr.to_string())
}

fn get_uptime() -> String {
    let start_time = START_TIME.lock().unwrap();
    let duration = start_time.elapsed().unwrap();
    format_duration(duration)
}

fn format_duration(duration: Duration) -> String {
    let secs = duration.as_secs();
    let hours = secs / 3600;
    let minutes = (secs % 3600) / 60;
    let seconds = secs % 60;
    format!("{:02}:{:02}:{:02}", hours, minutes, seconds)
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    println!("Starting web server...");

    let _start_time = *START_TIME.lock().unwrap();

    let port: u16 = env::var("PORT")
        .unwrap_or_else(|_| DEFAULT_PORT.to_string())
        .parse()
        .expect("PORT must be a valid number");

    HttpServer::new(move || {
        App::new()
            .service(root)
            .service(health)
            .service(my_ip)
            .service(new_uuid)
            .service(soh)
            .service(uptime)
            .default_service(web::to(not_found))
    })
    .bind(("0.0.0.0", port))?
    .run()
    .await
}