/*
 * Copyright 2020 cknoll1.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.ohdsi.cohortincidence;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.stream.Collectors;

/**
 * Utility class for reading classpath resources as strings.
 * This is a local replacement for org.ohdsi.circe.helper.ResourceHelper.
 *
 * @author cknoll1
 */
public final class ResourceHelper {

	private ResourceHelper() {
		// Prevent instantiation
	}

	/**
	 * Reads a classpath resource and returns its contents as a String.
	 *
	 * @param path The classpath resource path (e.g., "/resources/cohortincidence/sql/file.sql")
	 * @return The contents of the resource as a String
	 * @throws RuntimeException if the resource cannot be found or read
	 */
	public static String GetResourceAsString(String path) {
		try (InputStream inputStream = ResourceHelper.class.getResourceAsStream(path)) {
			if (inputStream == null) {
				throw new RuntimeException("Resource not found: " + path);
			}
			try (BufferedReader reader = new BufferedReader(
					new InputStreamReader(inputStream, StandardCharsets.UTF_8))) {
				return reader.lines().collect(Collectors.joining("\n"));
			}
		} catch (Exception e) {
			throw new RuntimeException("Error reading resource: " + path, e);
		}
	}
}
