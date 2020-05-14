## Realtime Programming lab 2

This laboratory work has following features: 
- Process events as soon as they come
- Have 3 groups of workers parsing and averaging the measurements
- Dynamically change the number of actors (up and down) depending on the load
- In case of a special `panic` message, kill the worker actor and then restart it 
- Make a message broker that supports multiple topics