use http::{
    HeaderValue,
    header::{CACHE_CONTROL, ETAG, LAST_MODIFIED},
};
use simple_eyre::eyre::Report;
use tracing_subscriber::{fmt, prelude::*};
use url::Url;
use warp::{Filter, Reply};

mod etag;
use etag::*;

#[derive(Clone)]
pub struct Args {
    /// Url for Dir
    dir: String,
    /// URL for loki
    loki: Option<String>,
    /// port to bind webserver on
    port: u16,
}

/// Parse the static website directory from the command line
fn parse_args() -> Result<Args, lexopt::Error> {
    use lexopt::prelude::*;

    let mut dir = None;
    let mut loki = None;
    let mut port = 80;
    let mut parser = lexopt::Parser::from_env();
    while let Some(arg) = parser.next()? {
        match arg {
            Short('d') | Long("directory") => {
                dir = Some(parser.value()?.parse()?);
            }
            Long("loki") => {
                loki = Some(parser.value()?.parse()?);
            }
            Long("port") => {
                port = parser.value()?.parse()?;
            }
            Long("help") => {
                println!("Usage: srv [-d|--directory=STRING --loki=URL --port=NUM]");
                std::process::exit(0);
            }
            _ => return Err(arg.unexpected()),
        }
    }

    if dir.is_none() {
        panic!("no directory provided")
    }

    Ok(Args {
        dir: dir.unwrap(),
        loki,
        port,
    })
}

#[tokio::main(flavor = "local")]
async fn main() -> Result<(), Report> {
    simple_eyre::install()?;
    let Args { dir, loki, port } = parse_args()?;
    if let Some(loki_url) = loki {
        let (layer, task) = tracing_loki::builder()
            .label("host", "website")?
            .extra_field("pid", format!("{}", std::process::id()))?
            .build_url(Url::parse(&loki_url).unwrap())?;
        tracing_subscriber::registry().with(layer).init();
        tokio::spawn(task);
    } else {
        tracing_subscriber::registry().with(fmt::layer()).init();
    }

    // the directory is a hashed nix store path. so its a great indicator
    // of whether the website content has changed.
    let etag = ETag::new(&dir);

    tracing::info!("serving {dir} on 0.0.0.0:{port} etag={}", &etag);

    let route = warp::fs::dir(dir)
        .map(move |f: warp::fs::File| {
            let mut res = f.into_response();
            res.headers_mut().remove(LAST_MODIFIED);
            res.headers_mut().insert(ETAG, etag.into());
            res.headers_mut()
                .insert(CACHE_CONTROL, HeaderValue::from_static("no-cache"));
            res
        })
        .with(warp::trace::request());

    warp::serve(route).run(([0, 0, 0, 0], port)).await;

    Ok(())
}
