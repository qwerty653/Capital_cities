terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

resource "docker_image" "apache" {
  name = "my-apache"
  build {
    context = "."
  }
  keep_locally = true
}

resource "docker_container" "apache" {
  name  = "my-apache-container"
  image = docker_image.apache.image_id

  ports {
    internal = 80
    external = 8080
  }
}
