/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

package com.hzgc.collect.ftp.command.impl;

import com.hzgc.collect.ftp.command.AbstractCommand;
import com.hzgc.collect.ftp.ftplet.FtpFile;
import com.hzgc.collect.ftp.ftplet.FtpException;
import com.hzgc.collect.ftp.ftplet.FtpReply;
import com.hzgc.collect.ftp.ftplet.FtpRequest;
import com.hzgc.collect.ftp.impl.FtpIoSession;
import com.hzgc.collect.ftp.impl.FtpServerContext;
import com.hzgc.collect.ftp.impl.LocalizedFtpReply;
import com.hzgc.collect.ftp.util.DateUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;

/**
 * <strong>Internal class, do not use directly.</strong>
 * 
 * <code>MDTM &lt;SP&gt; &lt;pathname&gt; &lt;CRLF&gt;</code><br>
 * 
 * Returns the date and time of when a file was modified.
 *
 * @author <a href="http://mina.apache.org">Apache MINA Project</a>
 */
public class MDTM extends AbstractCommand {

    private final Logger LOG = LoggerFactory.getLogger(MDTM.class);

    /**
     * Execute command
     */
    public void execute(final FtpIoSession session,
                        final FtpServerContext context, final FtpRequest request)
            throws IOException, FtpException {

        // reset state
        session.resetState();

        // argument check
        String fileName = request.getArgument();
        if (fileName == null) {
            session.write(LocalizedFtpReply.translate(session, request, context,
                    FtpReply.REPLY_501_SYNTAX_ERROR_IN_PARAMETERS_OR_ARGUMENTS,
                    "MDTM", null));
            return;
        }

        // get file object
        FtpFile file = null;
        try {
            file = session.getFileSystemView().getFile(fileName);
        } catch (Exception ex) {
            LOG.debug("Exception getting file object", ex);
        }
        if (file == null) {
            session.write(LocalizedFtpReply.translate(session, request, context,
                    FtpReply.REPLY_550_REQUESTED_ACTION_NOT_TAKEN, "MDTM",
                    fileName));
            return;
        }

        // now print date
        fileName = file.getAbsolutePath();
        if (file.doesExist()) {
            String dateStr = DateUtils.getFtpDate(file.getLastModified());
            session.write(LocalizedFtpReply.translate(session, request, context,
                    FtpReply.REPLY_213_FILE_STATUS, "MDTM", dateStr));
        } else {
            session.write(LocalizedFtpReply.translate(session, request, context,
                    FtpReply.REPLY_550_REQUESTED_ACTION_NOT_TAKEN, "MDTM",
                    fileName));
        }
    }
}
