import { IsIn, IsString, IsUUID, Matches, MaxLength } from 'class-validator';

export class VerifyOtpDto {
  @IsUUID()
  challengeId!: string;

  @Matches(/^\d{6}$/, { message: 'code must be 6 digits' })
  code!: string;

  @IsUUID()
  installId!: string;

  @IsIn(['android', 'ios'])
  platform!: 'android' | 'ios';

  @IsString()
  @MaxLength(32)
  appVersion!: string;
}
