{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateTags"
            ],
            "Resource": "arn:${partition}:ec2:*::snapshot/*",
            "Condition": {
                "ForAnyValue:StringEquals": {
                    "aws:TagKeys": [
                        "Orca"
                    ]
                },
                "StringEquals": {
                    "ec2:CreateAction": [
                        "CreateSnapshot",
                        "CreateSnapshots",
                        "CopySnapshot"
                    ]
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CopySnapshot",
                "ec2:ModifySnapshotAttribute"
            ],
            "Resource": "*",
            "Condition": {
                "StringNotLikeIfExists": {
                    "ec2:ResourceTag/OrcaOptOut": "*"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeSnapshots",
                "ec2:DescribeImages"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "kms:Decrypt",
                "kms:Encrypt",
                "kms:ReEncryptFrom",
                "kms:ReEncryptTo",
                "kms:CreateGrant",
                "kms:GenerateDataKeyWithoutPlaintext"
            ],
            "Resource": "*",
            "Condition": {
                "StringNotLikeIfExists": {
                    "aws:ResourceTag/OrcaOptOut": "*"
                },
                "StringLike": {
                    "kms:ViaService": "ec2.*.amazonaws.com"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "kms:DescribeKey",
                "kms:GetKeyPolicy",
                "kms:PutKeyPolicy"
            ],
            "Resource": "*",
            "Condition": {
                "StringNotLikeIfExists": {
                    "aws:ResourceTag/OrcaOptOut": "*"
                }
            }
        }
    ]
}
