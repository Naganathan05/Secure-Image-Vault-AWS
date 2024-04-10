resource "aws_dynamodb_table" "visitor_count" {
  name = var.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key = var.hash_key

  attribute {
    name = var.hash_key
    type = "S"
  }
}

resource "aws_dynamodb_table_item" "count" {
  table_name = aws_dynamodb_table.visitor_count.name
  hash_key = var.hash_key

  item = <<ITEM
  {
    "id"   : {"S": "0"},
    "count": {"N": "10"}
  }
  ITEM

  lifecycle {
    ignore_changes = [
      item
    ]
  }
}