# dx7render-docker

[learnfm](https://github.com/bwhitman/learnfm)'s DX7 implementation, dockerized.

WARNING: There might be some duplicates in the name, I would prefer
to slugify the patch filename.

```
docker pull turian/dx7render
# Or, build the docker yourself
#docker build -t turian/dx7render .
docker run --rm --mount source=`pwd`/output,target=/home/dx7/output,type=bind -it turian/dx7render bash
```

Within docker:
```
# Generate all patches with all notes in the MIDI range of a grand
# piano writing ogg files to output/
./run.py
```

See `bwhitman` branch to use latest version with Python 3 support.
