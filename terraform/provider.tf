provider "google" {
  credentials = file(var.auth_key)
  project = var.project_name
}