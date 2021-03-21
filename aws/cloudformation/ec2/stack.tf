resource "aws_cloudformation_stack" "main" {
  name = "NetworkingTest"

  parameters = {
    VPCCidr = "10.0.0.0/16"
  }

  template_body = file("stack.json")

  disable_rollback = true
}

output "stack_outputs" {
  value = aws_cloudformation_stack.main.outputs
}
