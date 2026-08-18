import { IsIn, IsString, Matches, MaxLength } from 'class-validator';

/**
 * E.164: a leading `+`, a non-zero country digit, then 7–14 more digits.
 * Shared by every DTO that accepts a phone number so the stored format is
 * unambiguous — `9876543210`, `09876543210`, and `+919876543210` must not be
 * able to become three different users.
 */
export const E164_PATTERN = /^\+[1-9]\d{7,14}$/;

export class RequestOtpDto {
  @IsString()
  @Matches(E164_PATTERN, {
    message: 'phone must be in E.164 format, e.g. +919876543210',
  })
  phone!: string;

  /**
   * Client-generated install identifier, held in secure storage so it survives
   * a local database wipe. Carried at this stage only to rate-limit per
   * device; the `Device` row is not created until the code is verified.
   */
  @IsString()
  @MaxLength(64)
  installId!: string;

  @IsIn(['android', 'ios'])
  platform!: 'android' | 'ios';
}
