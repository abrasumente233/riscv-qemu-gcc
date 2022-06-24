use std::fs::File;
use std::path::PathBuf;

use clap::Parser;

#[derive(Debug, Parser)]
struct Args {
    img: PathBuf,
    src: PathBuf,
    dst: PathBuf,
}

fn main() -> std::io::Result<()> {
    let args = Args::parse();

    let img_file = std::fs::OpenOptions::new()
        .read(true)
        .write(true)
        .open(args.img)?;

    let buf_stream = fscommon::BufStream::new(img_file);
    let fs = fatfs::FileSystem::new(buf_stream, fatfs::FsOptions::new())?;
    let root_dir = fs.root_dir();

    let mut src_file = File::open(args.src)?;
    let mut dst_file = root_dir.create_file(args.dst.to_str().unwrap())?;
    dst_file.truncate()?;
    std::io::copy(&mut src_file, &mut dst_file)?;

    Ok(())
}
