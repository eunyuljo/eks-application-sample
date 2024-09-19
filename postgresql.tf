# provider 설정
provider "aws" {
  region = "ap-northeast-2"  # 원하는 region으로 변경하세요
}

# 기존 VPC와 서브넷을 참조합니다
data "aws_vpc" "existing_vpc" {
  id = "vpc-00e7e31d7427ae524"  # 기존 VPC ID로 변경하세요
}

# 사용할 서브넷들을 참조합니다 (여러 개의 서브넷 ID를 지정)
data "aws_subnet" "existing_subnet_1" {
  id = "subnet-044d9418d551a5386"  # 첫 번째 서브넷 ID
}

data "aws_subnet" "existing_subnet_2" {
  id = "subnet-0bfe59237e8fdedd2"  # 두 번째 서브넷 ID
}

data "aws_subnet" "existing_subnet_3" {
  id = "subnet-0d6b3838ce2d68b53"  # 두 번째 서브넷 ID
}

# 서브넷 그룹 생성
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = [
    data.aws_subnet.existing_subnet_1.id,
    data.aws_subnet.existing_subnet_2.id,
    data.aws_subnet.existing_subnet_3.id
  ]

  tags = {
    Name = "rds-subnet-group"
  }
}

# 보안 그룹 생성
resource "aws_security_group" "rds_sg" {
  name        = "rds-postgres-sg"
  description = "Security group for RDS PostgreSQL"
  vpc_id      = data.aws_vpc.existing_vpc.id

  # Ingress Rule for PostgreSQL (TCP 5432)
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # 적절한 IP 범위로 제한하세요
  }

  # Egress Rule
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-postgres-sg"
  }
}

# RDS 인스턴스 생성
resource "aws_db_instance" "postgres_instance" {
  allocated_storage    = 20
  engine               = "postgres"
  engine_version       = "15"  # 원하는 PostgreSQL 버전으로 변경 가능
  instance_class       = "db.t3.micro"  # 적절한 인스턴스 타입으로 변경
  identifier           = "eyjo-postgres-instance"
  db_name              = "mydb"  # 데이터베이스 이름
  username             = "dbadmin"  # DB admin 사용자 이름
  password             = "password1234"  # 강력한 비밀번호로 변경
  parameter_group_name = "default.postgres15"  # 파라미터 그룹
  skip_final_snapshot  = true  # 종료 시 스냅샷 생성을 건너뜀
  publicly_accessible  = false  # 외부에서 접근할 수 없도록 설정

  # 기존 서브넷 그룹을 연결
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name

  # 보안 그룹 설정
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  tags = {
    Name = "postgres-instance"
  }
}

