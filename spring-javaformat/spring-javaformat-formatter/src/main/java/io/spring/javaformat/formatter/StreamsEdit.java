/*
 * Copyright 2017-2019 the original author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package io.spring.javaformat.formatter;

import java.io.IOException;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.util.regex.Pattern;

import org.eclipse.jface.text.Document;
import org.eclipse.jface.text.IDocument;
import org.eclipse.text.edits.TextEdit;

/**
 * An {@link Edit} that can be applied to IO Streams.
 *
 * @author Phillip Webb
 */
public class StreamsEdit {

	private static final Pattern TRAILING_WHITESPACE = Pattern.compile(" +$", Pattern.MULTILINE);

	private final String originalContent;

	private final TextEdit edit;

	StreamsEdit(String originalContent, TextEdit textEdit) {
		this.originalContent = originalContent;
		this.edit = textEdit;
	}

	public void writeTo(OutputStream outputStream) {
		writeTo(outputStream, StandardCharsets.UTF_8);
	}

	public void writeTo(OutputStream outputStream, Charset encoding) {
		try (OutputStreamWriter writer = new OutputStreamWriter(outputStream, encoding)) {
			writeTo(writer);
		}
		catch (IOException ex) {
			throw new RuntimeException(ex);
		}
	}

	public void writeTo(Appendable appendable) {
		try {
			appendable.append(getFormattedContent());
		}
		catch (Exception ex) {
			throw new RuntimeException(ex);
		}
	}

	public String getFormattedContent() throws Exception {
		try {
			IDocument document = new Document(this.originalContent);
			this.edit.apply(document);
			String formattedContent = document.get();
			return trimTrailingWhitespace(formattedContent);
		}
		catch (Exception ex) {
			throw new RuntimeException(ex);
		}
	}

	private String trimTrailingWhitespace(String content) {
		return TRAILING_WHITESPACE.matcher(content).replaceAll("");
	}

}
