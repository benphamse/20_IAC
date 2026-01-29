data "aws_ssm_parameter" "ami" {
  name = "/production/ami"

  depends_on = [aws_ssm_parameter.ami]
}


