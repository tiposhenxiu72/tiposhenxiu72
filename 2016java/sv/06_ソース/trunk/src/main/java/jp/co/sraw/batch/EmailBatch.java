package jp.co.sraw.batch;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import jp.co.sraw.dto.BatchPublicDto;
import jp.co.sraw.dto.EmailDto;
import jp.co.sraw.dto.NewsDto;
import jp.co.sraw.logger.LoggerWrapper;
import jp.co.sraw.logger.LoggerWrapperFactory;
import jp.co.sraw.service.BatchTargetService;

@Component
public class EmailBatch implements BatchRunner{
	private static final LoggerWrapper logger = LoggerWrapperFactory.getLogger(EmailBatch.class);

	@Autowired
	private BatchTargetService batchTargetService;

	public boolean run(Map<String, String> parameters) throws Exception {
		String targetDays = parameters.get("targetdays");
		int smallint = 0;
			try {
				smallint = Integer.parseInt(targetDays);
			} catch (Exception e) {
				throw e;
			}

			List<NewsDto> batchSupportList = new ArrayList<>();
			List<NewsDto> batchEventList = new ArrayList<>();
			List<NewsDto> batchInternshipList = new ArrayList<>();
			List<EmailDto> supportResultList = new ArrayList<>();
			List<EmailDto> eventResultList = new ArrayList<>();
			List<EmailDto> internshipResultList = new ArrayList<>();
			List<BatchPublicDto> evnetPublicResultList = new ArrayList<>();
			List<BatchPublicDto> internshipPublicResultList = new ArrayList<>();

			// お知らせ情報作成
			int i = 0;
			int j = 0;
			int k = 0;
			String infoKey = null;

			batchSupportList = batchTargetService.findAllBatchSupport();
			EmailDto emailDto = new EmailDto();

			for (i = 0; i < batchSupportList.size(); i++) {
				String infoRefKey = batchSupportList.get(i).getRefDataKey();
				String sendDate =  batchSupportList.get(i).getSupportStartDate().toString();
				String title = batchSupportList.get(i).getSupportTitle();
				String dataKbn = batchSupportList.get(i).getDataKbn();
				infoKey = "%03%";
				supportResultList = batchTargetService.findAllEmailBatch(infoKey);
				//タイトル
				emailDto.setEmailTitle(title);
				//公開日
				emailDto.setEmailSendDate(sendDate);
				//概要
				emailDto.setEmailMemo(batchSupportList.get(i).getSupportContent());
				//リンク先
				emailDto.setEmailUrl(batchSupportList.get(i).getUrl());

				batchTargetService.editEmailBatch(emailDto);
				batchTargetService.updateEmailBatch(infoRefKey,dataKbn);
			}

			batchEventList = batchTargetService.findAllBatchEvent();

			for (i = 0; i < batchEventList.size(); i++) {
				String infoRefKey = batchEventList.get(i).getRefDataKey();
				String sendDate =  batchEventList.get(i).getSupportStartDate().toString();
				String title = batchEventList.get(i).getSupportTitle();
				String dataKbn = batchEventList.get(i).getDataKbn();

				infoKey = "%01%";
				eventResultList = batchTargetService.findAllEmailBatch(infoKey);
				evnetPublicResultList = batchTargetService.findAllEventPublicBatch(infoRefKey);

				for (j = 0; j < evnetPublicResultList.size(); j++) {
					// 1:ROLEの場合
					if ("01".equals(dataKbn)) {
						for (k = 0; k < eventResultList.size(); k++) {
							if (evnetPublicResultList.get(j).getRole().equals(eventResultList.get(k).getEmailRole())) {
								// タイトル
								emailDto.setEmailTitle(title);
								// 配信日
								emailDto.setEmailSendDate(sendDate);
								// 場所
//								emailDto.setEmailPlace(batchEventList.get(i).getNewsPlace());
//								// 開催日
//								emailDto.setEmailStartDate(batchEventList.get(i).getNewsStartDate());
//								// 担当窓口
//								emailDto.setEmailPartyName(batchEventList.get(i).getNewsPartyName());
//								// 連絡先
//								emailDto.setEmailTelno(batchEventList.get(i).getNewsTelno());
//								// 概要
//								emailDto.setEmailMemo(batchEventList.get(i).getNewsContent());
								batchTargetService.editEmailBatch(emailDto);
							}
						}

						// 2:組織の場合
					} else if ("02".equals(dataKbn)) {
						for (k = 0; k < eventResultList.size(); k++) {
							if (evnetPublicResultList.get(j).getPartyCode()
									.equals(eventResultList.get(k).getEmailPartyCode())) {
								// タイトル
								emailDto.setEmailTitle(title);
								// 配信日
								emailDto.setEmailSendDate(sendDate);
								// 場所
//								emailDto.setEmailPlace(batchEventList.get(i).getNewsPlace());
//								// 開催日
//								emailDto.setEmailStartDate(batchEventList.get(i).getNewsStartDate());
//								// 担当窓口
//								emailDto.setEmailPartyName(batchEventList.get(i).getNewsPartyName());
//								// 連絡先
//								emailDto.setEmailTelno(batchEventList.get(i).getNewsTelno());
//								// 概要
//								emailDto.setEmailMemo(batchEventList.get(i).getNewsContent());
								batchTargetService.editEmailBatch(emailDto);
							}
						}
					}
				}
				batchTargetService.updateEmailBatch(infoRefKey,dataKbn);
			}

			batchInternshipList = batchTargetService.findAllBatchInternship();

			for (i = 0; i < batchInternshipList.size(); i++) {
				String infoRefKey = batchInternshipList.get(i).getRefDataKey();
				String sendDate =  batchInternshipList.get(i).getSupportStartDate().toString();
				String title = batchInternshipList.get(i).getSupportTitle();
				String dataKbn = batchInternshipList.get(i).getDataKbn();
				infoKey = "%02%";
				internshipResultList = batchTargetService.findAllEmailBatch(infoKey);
				internshipPublicResultList = batchTargetService.findAllInternshipPublicBatch(infoRefKey);

				for (j = 0; j < internshipPublicResultList.size(); j++) {
					// 1:ROLEの場合
					if ("01".equals(dataKbn)) {
						for (k = 0; k < internshipResultList.size(); k++) {
							if (internshipPublicResultList.get(j).getRole()
									.equals(internshipResultList.get(k).getEmailRole())) {
								// タイトル
								emailDto.setEmailTitle(title);
								// 配信日
								emailDto.setEmailSendDate(sendDate);
								// 担当窓口
//								emailDto.setEmailPartyName(batchInternshipList.get(i).getNewsPartyName());
//								// 連絡先
//								emailDto.setEmailTelno(batchInternshipList.get(i).getNewsTelno());
//								// 応募対象
//								emailDto.setEmailRecruit(batchInternshipList.get(i).getNewsRecruit());
//								// 応募期間（開始）
//								emailDto.setEmailStartDate(batchInternshipList.get(i).getNewsStartDate());
//								// 応募期間（終了）
//								emailDto.setEmailEndDate(batchInternshipList.get(i).getNewsEndDate());
//								// 概要
//								emailDto.setEmailMemo(batchInternshipList.get(i).getNewsContent());
								batchTargetService.editEmailBatch(emailDto);
							}
						}

						// 2:組織の場合
					} else if ("02".equals(dataKbn)) {
						for (k = 0; k < internshipResultList.size(); k++) {
							if (internshipPublicResultList.get(j).getPartyCode()
									.equals(internshipResultList.get(k).getEmailPartyCode())) {
								// タイトル
								emailDto.setEmailTitle(title);
								// 配信日
								emailDto.setEmailSendDate(sendDate);
								// 担当窓口
//								emailDto.setEmailPartyName(batchInternshipList.get(i).getNewsPartyName());
//								// 連絡先
//								emailDto.setEmailTelno(batchInternshipList.get(i).getNewsTelno());
//								// 応募対象
//								emailDto.setEmailRecruit(batchInternshipList.get(i).getNewsRecruit());
//								// 応募期間（開始）
//								emailDto.setEmailStartDate(batchInternshipList.get(i).getNewsStartDate());
//								// 応募期間（終了）
//								emailDto.setEmailEndDate(batchInternshipList.get(i).getNewsEndDate());
//								// 概要
//								emailDto.setEmailMemo(batchInternshipList.get(i).getNewsContent());
								batchTargetService.editEmailBatch(emailDto);
							}
						}
					}
				}
				batchTargetService.updateEmailBatch(infoRefKey,dataKbn);
			}

			return true;
		}
	}
