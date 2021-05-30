# Yourfactory
This is an educational project of web-service for sending 3D models to some 3D-printing service.
Current version is available at [Heroku](https://yourfactory.herokuapp.com).

Project check-list:
- [x] Registration and authorization
- [x] Model upload
- [x] 3D preview
- [x] Store front
- [ ] Payments

To run locally:
1. The easiest way is to install [Docker](https://www.docker.com/get-started) and `docker-compose`. Also works with [Podman](https://podman.io/getting-started/) and `podman-compose`.
2. Add `.env` file to the project root with environment variables set in `docker-compose.yml`
3. `docker-compose up`