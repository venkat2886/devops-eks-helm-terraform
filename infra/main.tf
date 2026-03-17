provider "aws" {
  region = var.region
}

resource "aws_ecr_repository" "app" {
  name = "${var.project}-sample-app"
}