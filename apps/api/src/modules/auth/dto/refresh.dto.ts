import { IsString, IsUUID, Length } from 'class-validator';

export class RefreshDto {
  @IsString()
  @Length(32, 512)
  refreshToken!: string;

  /** Server-assigned device id, returned by `verify` and carried in the JWT. */
  @IsUUID()
  deviceId!: string;
}
