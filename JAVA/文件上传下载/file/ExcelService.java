package jp.co.sraw.file;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.List;

import org.springframework.stereotype.Service;

import jp.co.sraw.common.CommonConst;
import jp.co.sraw.common.CommonForm;
import jp.co.sraw.common.UserInfo;
import jp.co.sraw.logger.LoggerWrapper;
import jp.co.sraw.logger.LoggerWrapperFactory;
import jp.co.sraw.util.PoiBook;

@SuppressWarnings("rawtypes")
@Service
public class ExcelService<F extends CommonForm, H extends AbstractExcelHelper> {

	private static final LoggerWrapper logger = LoggerWrapperFactory.getLogger(ExcelService.class);

	private String xlsTemplateName;

	public String getXlsTemplateName() {
		return xlsTemplateName;
	}

	public void setXlsTemplateName(String xlsTemplateName) {
		this.xlsTemplateName = xlsTemplateName;
	}

	@SuppressWarnings("unchecked")
	public ByteArrayOutputStream getExcel(UserInfo userInfo, List<F> list, H helper) {

		String templatePath = CommonConst.RESPATH_DOC_TEMPLATE + this.xlsTemplateName;

		try (PoiBook book = PoiBook.fromResource(templatePath)) {
			helper.buildExcelDocument(book, list);
			ByteArrayOutputStream baos = new ByteArrayOutputStream();
			book.write(baos);
			return baos;
		} catch (IOException e) {
			logger.error("IOException exporting a execlfile ");
			return null;
		} catch (Exception e) {
			logger.error("unexpected error while exporting a excelfile ");
			return null;
		}
	}

}
