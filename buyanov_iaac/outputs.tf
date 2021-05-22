# Output variables
# Позволяют сохранить выходные значения после создания ресурсов.
# Облегчают процедуру поиска нужных данных
# Используются в модулях как входные переменные для других модулей

# EC instances dns public records
output "web_servers_public_dns_records" {
  value = aws_instance.web_server.*.public_dns
}

