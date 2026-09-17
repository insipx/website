use http::header::HeaderValue;
use std::fmt::{Display, Formatter};
use std::hash::{DefaultHasher, Hash, Hasher};
use std::str::FromStr;

/// An `ETag` is a unique identifier for a website
/// if an etag changes the browser will refresh the site
#[derive(Copy, Clone, PartialEq, Eq)]
pub struct ETag {
    inner: u64,
}

impl FromStr for ETag {
    type Err = std::num::ParseIntError;
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        Ok(ETag { inner: s.parse()? })
    }
}

impl Display for ETag {
    fn fmt(&self, f: &mut Formatter<'_>) -> Result<(), std::fmt::Error> {
        write!(f, "{}", self.inner)
    }
}

impl ETag {
    pub fn new<T: Hash>(data: &T) -> Self {
        let mut hasher = DefaultHasher::new();
        data.hash(&mut hasher);
        Self {
            inner: hasher.finish(),
        }
    }
}

impl From<ETag> for HeaderValue {
    fn from(value: ETag) -> HeaderValue {
        HeaderValue::from_str(&value.to_string()).expect("A u64 will only result in visible ASCII")
    }
}

impl Default for ETag {
    fn default() -> Self {
        let now = std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .map(|d| d.as_secs())
            .unwrap_or(0);
        let mut hasher = DefaultHasher::new();
        now.hash(&mut hasher);
        ETag {
            inner: hasher.finish(),
        }
    }
}
